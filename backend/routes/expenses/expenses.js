const express = require('express');
const dbOperations = require('../../../database/dbOperations');
const { authenticateToken } = require('../../middleware/jwt');
const router = express.Router();

router.get('/get-expenses/:id', authenticateToken, async (req, res) => {
    const { id } = req.params;
    try {
        const expenses = await dbOperations.getExpenses(id);
        res.status(200).json({ expenses: expenses, message: "Success" });
    } catch (err) {
        console.log(err);
        res.status(500).json({ message: "Error in getting expenses" });
    }
});

router.delete('/remove-expense', authenticateToken, async (req, res) => {
    const { id } = req.body;
    const loggedInUsername = req.user.username;
    try {
        await dbOperations.removeExpense(id, loggedInUsername);
        res.status(200).json({ message: "Expense removed successfully" });
    } catch (err) {
        console.log(err);
        res.status(500).json({ message: "Error in removing expense" });
    }
});

router.post('/add-expense', authenticateToken, async (req, res) => {
    const { amount, category, date, notes } = req.body;
    const username = req.user.username;
    try {
        await dbOperations.addExpense(username, amount, category, date, notes);
        res.status(200).json({ message: "Expense added successfully" });
    } catch (err) {
        console.log(err);
        res.status(500).json({ message: "Error in adding expense" });
    }
});

router.put('/modify-expense', authenticateToken, async (req, res) => {
    const { id, amount, category, notes } = req.body;
    const loggedInUsername = req.user.username;
    try {
        await dbOperations.modifyExpense(id, loggedInUsername, amount, category, notes);
        res.status(200).json({ message: "Expense modified successfully" });
    } catch (err) {
        console.log(err);
        res.status(500).json({ message: "Error in modifying expense" });
    }
});

module.exports = router;