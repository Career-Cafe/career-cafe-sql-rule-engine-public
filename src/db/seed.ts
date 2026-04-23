import { readFileSync } from "fs";
import { resolve } from "path";
import { fileURLToPath } from "url";
import { Pool } from "pg";
import { settings } from "../config/settings.js";

interface ProblemRecord {
  problem_id: string;
  title: string;
  pattern: string;
  schema: string;
  query: string;
}

interface ExpectedResultRecord {
  problem_id: string;
  result_hash: string;
  result_rows: string;
}

const __dirname = fileURLToPath(new URL(".", import.meta.url));
const problemsPath = resolve(__dirname, "../data/problems.json");
const expectedResultsPath = resolve(__dirname, "../data/expected-results.json");

function readJson<T>(path: string): T {
  return JSON.parse(readFileSync(path, "utf-8")) as T;
}

async function seed(): Promise<void> {
  const pool = new Pool({ connectionString: settings.DATABASE_URL });
  const problems = readJson<ProblemRecord[]>(problemsPath);
  const expectedResults = readJson<ExpectedResultRecord[]>(expectedResultsPath);

  const client = await pool.connect();
  try {
    await client.query("BEGIN");

    for (const problem of problems) {
      await client.query(
        `INSERT INTO problems (problem_id, title, pattern, schema_name, query)
         VALUES ($1, $2, $3, $4, $5)
         ON CONFLICT (problem_id) DO UPDATE
         SET title = EXCLUDED.title,
             pattern = EXCLUDED.pattern,
             schema_name = EXCLUDED.schema_name,
             query = EXCLUDED.query`,
        [problem.problem_id, problem.title, problem.pattern, problem.schema, problem.query],
      );
    }

    for (const expected of expectedResults) {
      await client.query(
        `INSERT INTO expected_results (problem_id, schema_name, result_hash, result_rows)
         VALUES ($1, $2, $3, $4::jsonb)
         ON CONFLICT (problem_id, schema_name) DO UPDATE
         SET result_hash = EXCLUDED.result_hash,
             result_rows = EXCLUDED.result_rows`,
        [expected.problem_id, "ecommerce", expected.result_hash, expected.result_rows],
      );
    }

    // Seed the ecommerce schema
    const ecommerceSeedPath = resolve(__dirname, "ecommerce-seed.sql");
    const ecommerceSeedSql = readFileSync(ecommerceSeedPath, "utf-8");
    await client.query(ecommerceSeedSql);

    await client.query("COMMIT");
  } catch (error) {
    await client.query("ROLLBACK");
    throw error;
  } finally {
    client.release();
    await pool.end();
  }
}

void seed()
  .then(() => {
    console.log("Seed completed.");
  })
  .catch((error) => {
    console.error("Seed failed:", error);
    process.exit(1);
  });
