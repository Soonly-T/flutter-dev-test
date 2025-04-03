const db= require("./database.js")

const addUser=(username,email,hashedPass)=>{
    try{
        db.run(`INSERT INTO USERS(USERNAME, EMAIL, HASHED_PASS) VALUES (?,?,?)`,[username,email,hashedPass], function(err){
          if(err){
            console.log(err)
          }
        })
      }catch (err){
        console.log(err)
    
      }

}

const removeUser=(username)=>{
    try{
        db.run("DELETE FROM EXPENSE WHERE USER_ID IN (SELECT ID FROM USERS WHERE USERNAME = ?) ",username, function(err){
            if (err){
                console.log(err)
            }
        })
        db.run("DELETE FROM USERS WHERE USERNAME = ?",username, function(err){
            if (err){
                console.log(err)
            }
        })

    }catch(err){
        console.log(err)
    }}

//approach 1
const patchUsername=(oldUsername,newUsername)=>{
    try{
        db.run("UPDATE USERS SET USERNAME = ? WHERE USERNAME = ?" [newUsername,oldUsername],function(err){
            if (err){
                console.log(err)
            }
        })
    }catch(err){
        console.log(err)
    }
}


// //approach 2
// const patchUsername=(email,username)=>{
//     try{
//         db.run("UPDATE USERS SET USERNAME =? WHERE EMAIL = ?", [username,email],function(err){
//             if(err){
//                 console.log(err)
//             }
//         })
//     }catch(err){
//         console.log(err)
//     }
// }

const patchEmail=(newPassword,username)=>{
    try{
        db.run("UPDATE USERS SET EMAIL = ? WHERE USERNAME = ?" [newEmail,username],function(err){
            if (err){
                console.log(err)
            }
        })
    }catch(err){
        console.log(err)
    }
}
// don't forget patchPassword
const addExpense = (username, amount, category, date, notes) => {
    try {
        db.run("INSERT INTO EXPENSE (USER_ID, AMOUNT, CATEGORY, DATE, NOTES) VALUES ((SELECT ID FROM USERS WHERE USERNAME = ?), ?, ?, ?, ?)", [username, amount, category, date, notes], function(err) {
            if (err) {
                console.log(err);
            }
        });
    } catch (err) {
        console.log(err);
    }
};

const modifyExpense = (id, username, amount, category, notes) => {
    try {
        db.run("UPDATE EXPENSE SET AMOUNT = ?, CATEGORY = ?, NOTES = ? WHERE ID = ? AND USER_ID = (SELECT ID FROM USERS WHERE USERNAME = ?)", [amount, category, date, notes, id, username], function(err) {
            if (err) {
                console.log(err);
            }
        });
    } catch (err) {
        console.log(err);
    }
};

const removeExpense = (id, username) => {
    try {
        db.run("DELETE FROM EXPENSE WHERE ID = ? AND USER_ID = (SELECT ID FROM USERS WHERE USERNAME = ?)", [id, username], function(err) {
            if (err) {
                console.log(err);
            }
        });
    } catch (err) {
        console.log(err);
    }
};

const getExpenses = async(id,fromDate,toDate) => {

    try {
        if (fromDate && toDate) {
            const rows = await db.all("SELECT * FROM EXPENSE WHERE USER_ID = (SELECT ID FROM USERS WHERE ID = ?) AND DATE BETWEEN ? AND ?", [id, fromDate, toDate]);
            return rows;
        }else if (fromDate) {
            const rows = await db.all("SELECT * FROM EXPENSE WHERE USER_ID = (SELECT ID FROM USERS WHERE ID = ?) AND DATE >= ?", [id, fromDate]);
            return rows;
        }else if (toDate) {
            const rows = await db.all("SELECT * FROM EXPENSE WHERE USER_ID = (SELECT ID FROM USERS WHERE ID = ?) AND DATE <= ?", [id, toDate]);
            return rows;
        }else {
            const rows = await db.all("SELECT * FROM EXPENSE WHERE USER_ID = (SELECT ID FROM USERS WHERE ID = ?)", [id]);
            return rows;
        }
    } catch (err) {
        console.log(err);
    }

}

const getHashedPass=(username)=>{
    try{
        const hashedPass= db.get("SELECT HASHED_PASS FROM USERS WHERE USERNAME = ?",[username])
        return hashedPass
    }catch(err){
        console.log(err)
    }
}


module.exports = {addUser,removeUser,patchUsername,patchEmail,addExpense,modifyExpense,removeExpense,getExpenses,getHashedPass}
