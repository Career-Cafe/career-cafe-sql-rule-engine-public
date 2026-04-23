CREATE TABLE "expected_results" (
	"problem_id" text NOT NULL,
	"schema_name" text NOT NULL,
	"result_hash" text NOT NULL,
	"result_rows" jsonb
);
--> statement-breakpoint
CREATE TABLE "problems" (
	"problem_id" text PRIMARY KEY NOT NULL,
	"title" text NOT NULL,
	"pattern" text NOT NULL,
	"schema_name" text NOT NULL,
	"query" text NOT NULL
);
--> statement-breakpoint
CREATE INDEX "idx_expected_results_problem_id" ON "expected_results" USING btree ("problem_id");--> statement-breakpoint
CREATE UNIQUE INDEX "uniq_expected_results_problem_schema" ON "expected_results" USING btree ("problem_id","schema_name");