CREATE TABLE "attempt_runs" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"attempt_id" uuid,
	"session_question_id" uuid NOT NULL,
	"query_text" text NOT NULL,
	"query_hash" text NOT NULL,
	"output" jsonb,
	"error_text" text,
	"runtime_ms" integer,
	"rule_version_used" integer,
	"ran_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "interview_sessions" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"user_id" uuid NOT NULL,
	"mode" text DEFAULT 'interview' NOT NULL,
	"status" text DEFAULT 'active' NOT NULL,
	"started_at" timestamp DEFAULT now() NOT NULL,
	"ended_at" timestamp,
	"readiness_check_passed" boolean DEFAULT false NOT NULL
);
--> statement-breakpoint
CREATE TABLE "problem_solutions" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"problem_id" uuid NOT NULL,
	"reference_solution_query" text NOT NULL,
	"created_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
ALTER TABLE "auth_sessions" DISABLE ROW LEVEL SECURITY;--> statement-breakpoint
ALTER TABLE "problem_run_counts" DISABLE ROW LEVEL SECURITY;--> statement-breakpoint
ALTER TABLE "problem_runs" DISABLE ROW LEVEL SECURITY;--> statement-breakpoint
DROP TABLE "auth_sessions" CASCADE;--> statement-breakpoint
DROP TABLE "problem_run_counts" CASCADE;--> statement-breakpoint
DROP TABLE "problem_runs" CASCADE;--> statement-breakpoint
ALTER TABLE "expected_results" DROP CONSTRAINT "expected_results_problem_id_problems_problem_id_fk";
--> statement-breakpoint
ALTER TABLE "session_questions" DROP CONSTRAINT "session_questions_problem_id_problems_problem_id_fk";
--> statement-breakpoint
DROP INDEX "uniq_expected_results_problem_schema";--> statement-breakpoint
ALTER TABLE "attempts" ALTER COLUMN "id" SET DATA TYPE uuid;--> statement-breakpoint
ALTER TABLE "attempts" ALTER COLUMN "id" SET DEFAULT gen_random_uuid();--> statement-breakpoint
ALTER TABLE "attempts" ALTER COLUMN "session_question_id" SET DATA TYPE uuid;--> statement-breakpoint
ALTER TABLE "expected_results" ALTER COLUMN "problem_id" SET DATA TYPE uuid;--> statement-breakpoint
ALTER TABLE "session_questions" ALTER COLUMN "id" SET DATA TYPE uuid;--> statement-breakpoint
ALTER TABLE "session_questions" ALTER COLUMN "id" SET DEFAULT gen_random_uuid();--> statement-breakpoint
ALTER TABLE "session_questions" ALTER COLUMN "problem_id" SET DATA TYPE uuid;--> statement-breakpoint
ALTER TABLE "session_questions" ALTER COLUMN "problem_id" SET NOT NULL;--> statement-breakpoint
ALTER TABLE "attempts" ADD COLUMN "user_id" uuid NOT NULL;--> statement-breakpoint
ALTER TABLE "attempts" ADD COLUMN "status" text DEFAULT 'pending' NOT NULL;--> statement-breakpoint
ALTER TABLE "attempts" ADD COLUMN "submitted_at" timestamp DEFAULT now() NOT NULL;--> statement-breakpoint
ALTER TABLE "expected_results" ADD COLUMN "id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL;--> statement-breakpoint
ALTER TABLE "expected_results" ADD COLUMN "solution_id" uuid;--> statement-breakpoint
ALTER TABLE "expected_results" ADD COLUMN "rows" jsonb;--> statement-breakpoint
ALTER TABLE "expected_results" ADD COLUMN "rows_hash" text NOT NULL;--> statement-breakpoint
ALTER TABLE "expected_results" ADD COLUMN "rule_version_snapshot" integer;--> statement-breakpoint
ALTER TABLE "expected_results" ADD COLUMN "is_active" boolean DEFAULT true NOT NULL;--> statement-breakpoint
ALTER TABLE "expected_results" ADD COLUMN "generated_at" timestamp DEFAULT now() NOT NULL;--> statement-breakpoint
ALTER TABLE "problems" ADD COLUMN "id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL;--> statement-breakpoint
ALTER TABLE "problems" ADD COLUMN "question_text" text NOT NULL;--> statement-breakpoint
ALTER TABLE "problems" ADD COLUMN "difficulty" text NOT NULL;--> statement-breakpoint
ALTER TABLE "problems" ADD COLUMN "is_free" boolean DEFAULT false NOT NULL;--> statement-breakpoint
ALTER TABLE "problems" ADD COLUMN "created_at" timestamp DEFAULT now() NOT NULL;--> statement-breakpoint
ALTER TABLE "session_questions" ADD COLUMN "session_id" uuid NOT NULL;--> statement-breakpoint
ALTER TABLE "session_questions" ADD COLUMN "order_index" integer NOT NULL;--> statement-breakpoint
ALTER TABLE "session_questions" ADD COLUMN "timer_enabled" boolean DEFAULT false NOT NULL;--> statement-breakpoint
ALTER TABLE "session_questions" ADD COLUMN "time_limit_seconds" integer;--> statement-breakpoint
ALTER TABLE "session_questions" ADD COLUMN "status" text DEFAULT 'pending' NOT NULL;--> statement-breakpoint
ALTER TABLE "session_questions" ADD COLUMN "used_at" timestamp;--> statement-breakpoint
ALTER TABLE "attempt_runs" ADD CONSTRAINT "attempt_runs_attempt_id_attempts_id_fk" FOREIGN KEY ("attempt_id") REFERENCES "public"."attempts"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "attempt_runs" ADD CONSTRAINT "attempt_runs_session_question_id_session_questions_id_fk" FOREIGN KEY ("session_question_id") REFERENCES "public"."session_questions"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "interview_sessions" ADD CONSTRAINT "interview_sessions_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "problem_solutions" ADD CONSTRAINT "problem_solutions_problem_id_problems_id_fk" FOREIGN KEY ("problem_id") REFERENCES "public"."problems"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
CREATE INDEX "idx_attempt_runs_attempt_id" ON "attempt_runs" USING btree ("attempt_id");--> statement-breakpoint
CREATE INDEX "idx_attempt_runs_session_question_id" ON "attempt_runs" USING btree ("session_question_id");--> statement-breakpoint
CREATE INDEX "idx_attempt_runs_query_hash" ON "attempt_runs" USING btree ("query_hash");--> statement-breakpoint
CREATE INDEX "idx_interview_sessions_user_id" ON "interview_sessions" USING btree ("user_id");--> statement-breakpoint
CREATE INDEX "idx_interview_sessions_status" ON "interview_sessions" USING btree ("status");--> statement-breakpoint
CREATE INDEX "idx_problem_solutions_problem_id" ON "problem_solutions" USING btree ("problem_id");--> statement-breakpoint
ALTER TABLE "attempts" ADD CONSTRAINT "attempts_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "expected_results" ADD CONSTRAINT "expected_results_problem_id_problems_id_fk" FOREIGN KEY ("problem_id") REFERENCES "public"."problems"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "session_questions" ADD CONSTRAINT "session_questions_session_id_interview_sessions_id_fk" FOREIGN KEY ("session_id") REFERENCES "public"."interview_sessions"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "session_questions" ADD CONSTRAINT "session_questions_problem_id_problems_id_fk" FOREIGN KEY ("problem_id") REFERENCES "public"."problems"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
CREATE INDEX "idx_attempts_session_question_id" ON "attempts" USING btree ("session_question_id");--> statement-breakpoint
CREATE INDEX "idx_attempts_user_id" ON "attempts" USING btree ("user_id");--> statement-breakpoint
CREATE INDEX "idx_expected_results_is_active" ON "expected_results" USING btree ("is_active");--> statement-breakpoint
CREATE INDEX "idx_problems_difficulty" ON "problems" USING btree ("difficulty");--> statement-breakpoint
CREATE INDEX "idx_session_questions_session_id" ON "session_questions" USING btree ("session_id");--> statement-breakpoint
CREATE INDEX "idx_session_questions_problem_id" ON "session_questions" USING btree ("problem_id");--> statement-breakpoint
ALTER TABLE "attempts" DROP COLUMN "explanation_text";--> statement-breakpoint
ALTER TABLE "attempts" DROP COLUMN "edge_case_text";--> statement-breakpoint
ALTER TABLE "attempts" DROP COLUMN "is_correct";--> statement-breakpoint
ALTER TABLE "attempts" DROP COLUMN "final_submitted_at";--> statement-breakpoint
ALTER TABLE "attempts" DROP COLUMN "feedback_summary";--> statement-breakpoint
ALTER TABLE "attempts" DROP COLUMN "rubric_scores";--> statement-breakpoint
ALTER TABLE "attempts" DROP COLUMN "rule_results";--> statement-breakpoint
ALTER TABLE "expected_results" DROP COLUMN "schema_name";--> statement-breakpoint
ALTER TABLE "expected_results" DROP COLUMN "result_hash";--> statement-breakpoint
ALTER TABLE "expected_results" DROP COLUMN "result_rows";--> statement-breakpoint
ALTER TABLE "problems" DROP COLUMN "problem_id";--> statement-breakpoint
ALTER TABLE "problems" DROP COLUMN "pattern";--> statement-breakpoint
ALTER TABLE "problems" DROP COLUMN "schema_name";--> statement-breakpoint
ALTER TABLE "problems" DROP COLUMN "query";--> statement-breakpoint
ALTER TABLE "session_questions" DROP COLUMN "user_id";--> statement-breakpoint
ALTER TABLE "session_questions" DROP COLUMN "session_mode";--> statement-breakpoint
ALTER TABLE "session_questions" DROP COLUMN "created_at";