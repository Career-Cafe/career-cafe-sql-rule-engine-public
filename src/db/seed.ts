import { readFileSync } from "fs";
import { resolve } from "path";
import { fileURLToPath } from "url";
import { randomUUID } from "crypto";
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
  const problemsData = readJson<ProblemRecord[]>(problemsPath);
  const expectedResultsData = readJson<ExpectedResultRecord[]>(expectedResultsPath);

  const client = await pool.connect();
  try {
    await client.query("BEGIN");

    // Create a mapping of problem_id to UUID for reference
    const problemIdMap: Record<string, string> = {};

    // Seed problems and problem_solutions
    for (const problemRecord of problemsData) {
      const problemId = randomUUID();
      problemIdMap[problemRecord.problem_id] = problemId;

      // Determine difficulty level from pattern or use as-is
      const difficulty = problemRecord.pattern.split("/")[0].trim() || "intermediate";

      // Insert problem
      await client.query(
        `INSERT INTO problems (id, title, question_text, difficulty, is_free, created_at)
         VALUES ($1, $2, $3, $4, $5, NOW())`,
        [
          problemId,
          problemRecord.title,
          `Solve: ${problemRecord.title}`, // Use generated question text
          difficulty,
          false, // Default to not free
        ],
      );

      // Insert problem solution with the query as reference_solution_query
      await client.query(
        `INSERT INTO problem_solutions (id, problem_id, reference_solution_query, created_at)
         VALUES ($1, $2, $3, NOW())`,
        [randomUUID(), problemId, problemRecord.query],
      );
    }

    // Seed expected results
    for (const expectedRecord of expectedResultsData) {
      const problemId = problemIdMap[expectedRecord.problem_id];
      if (!problemId) {
        console.warn(`No mapping found for problem_id: ${expectedRecord.problem_id}`);
        continue;
      }

      // Parse result_rows if it's a string JSON
      let rowsData;
      try {
        rowsData = typeof expectedRecord.result_rows === "string" 
          ? JSON.parse(expectedRecord.result_rows) 
          : expectedRecord.result_rows;
      } catch {
        rowsData = null;
      }

      // Insert expected result
      await client.query(
        `INSERT INTO expected_results (id, problem_id, rows, rows_hash, is_active, generated_at)
         VALUES ($1, $2, $3::jsonb, $4, $5, NOW())`,
        [
          randomUUID(),
          problemId,
          JSON.stringify(rowsData),
          expectedRecord.result_hash,
          true,
        ],
      );
    }

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
