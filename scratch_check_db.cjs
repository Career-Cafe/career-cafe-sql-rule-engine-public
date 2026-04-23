const { Client } = require('pg');
const client = new Client({ connectionString: 'postgresql://neondb_owner:npg_qIYpv0tNmCD5@ep-little-boat-ant828mp-pooler.c-6.us-east-1.aws.neon.tech/neondb?sslmode=require' });
client.connect().then(() => {
  return client.query(`
    SELECT table_schema, table_name 
    FROM information_schema.tables 
    WHERE table_schema NOT IN ('information_schema', 'pg_catalog')
  `);
}).then(res => {
  console.log(res.rows);
  return client.end();
}).catch(console.error);
