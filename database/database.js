const express= require('express');
const sqlite3 = require('sqlite3').verbose();

const db=new sqlite3.Database('appinfo', (err) => {
  if (err) {
    console.error('Error opening database ' + err.message);
  }
  else {
    console.log('Connected to the SQLite database.');
    
  }  
})

module.exports = db;







// db.all("SELECT name FROM sqlite_master WHERE type='table';", [], (err, tables) => {
//   if (err) {
//     console.error('Error fetching table names: ' + err.message);
//   } else {
//     tables.forEach(table => {
//       const tableName = table.name;
//       db.all(`PRAGMA table_info(${tableName});`, [], (err, rows) => {
//         if (err) {
//           console.error(`Error fetching headers for table ${tableName}: ` + err.message);
//         } else {
//           const headers = rows.map(row => row.name);
//           console.log(`Table: ${tableName}, Headers:`, headers);
//         }
//       });
//     });
//   }
// });


