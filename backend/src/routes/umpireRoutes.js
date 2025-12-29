const express = require('express');
const umpireController = require('../controllers/umpireController');
const { verifyToken, requireRole } = require('../middleware/authMiddleware');

const router = express.Router();

// All routes require umpire role
router.use(verifyToken);
router.use(requireRole('umpire'));

router.post('/matches', umpireController.createMatch);
router.get('/matches', umpireController.listUmpireMatches);
router.get('/matches/:matchId', umpireController.getMatchDetails);
router.put('/matches/:matchId/score', umpireController.updateMatchScore);
router.post('/matches/:matchId/players', umpireController.addPlayerToMatch);
router.put('/matches/:matchId/player-stats/:playerStatId', umpireController.updatePlayerStats);

module.exports = router;



