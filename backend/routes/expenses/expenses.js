const express = require('express');
const dbOperations = require('../../../database/dbOperations');
const router=express.Router();

router.get('/get-expenses', async(req, res) => {
    const {id,startDate,endDate}=req.body
    dbOperations.getExpenses(id,startDate,endDate);
    
});

router.delete(`/remove-expense`, async(req, res) => {
    const{id,username}=req.body
    dbOperations.removeExpense(id,username);
});

router.post(`/add-expense`, async(req, res) => {
    const {username,amount,category,date,notes}=req.body
    dbOperations.addExpense(username,amount,category,date,notes);
    
})

router.put(`/modify-expense`, async(req, res) => {
    const {id,username,amount,category,notes}=req.body
    dbOperations.modifyExpense(id,username,amount,category,notes);
    
})

module.exports = router;
