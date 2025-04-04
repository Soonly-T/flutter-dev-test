const express = require('express');
const dbOperations = require('../../../database/dbOperations');
const router=express.Router();

router.get('/get-expenses', async (req, res) => {
    const { id, startDate, endDate } = req.body;
    try {
        await dbOperations.getExpenses(id, startDate, endDate);
        res.status(200).json({ message: "Success" });
    } catch (err) {
        console.log(err);
        res.status(500).json({ message: "Error in getting expenses" });
    }
});

router.delete('/remove-expense', async (req, res) => {
    const { id, username } = req.body;
    try {
        await dbOperations.removeExpense(id, username);
        res.status(200).json({ message: "Expense removed successfully" });  
    } catch (err) {
        console.log(err);
        res.status(500).json({ message: "Error in removing expense" });
    }
});

router.post('/add-expense', async (req, res) => {
    const { username, amount, category, date, notes } = req.body;
    try {
        await dbOperations.addExpense(username, amount, category, date, notes);
        res.status(200).json({ message: "Expense added successfully" });
    } catch (err) {
        console.log(err);
        res.status(500).json({ message: "Error in adding expense" });
    }
});

router.put('/modify-expense', async (req, res) => {
    const { id, username, amount, category, notes } = req.body;
    try {
        await dbOperations.modifyExpense(id, username, amount, category, notes);
        res.status(200).json({ message: "Expense modified successfully" });
    } catch (err) {
        console.log(err);
        res.status(500).json({ message: "Error in modifying expense" });
    }
});

module.exports = router;
