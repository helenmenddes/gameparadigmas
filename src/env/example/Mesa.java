// CArtAgO artifact code for project stones

package example;

import java.util.ArrayList;

import cartago.*;

public class Mesa extends Artifact {
	private ArrayList<Integer> towers;
	private ArrayList<String> players = new ArrayList();
	private int curPlayerId;
	private int gameStatus = 0; //0 Not started 
	private boolean printlogs = false;

	void init(int players) {
		defineObsProperty("totalPlayers", players);
	}

	@OPERATION
	void reset() {
		if (getCurrentOpAgentId().getAgentName().equals("judge")) {
			gameStatus = 0;
			if (printlogs)
				System.out.println("Reset called!");

			if (towers != null) {
				for (int i = 1; i < towers.size(); i++) {
					removeObsPropertyByTemplate("tower", i, towers.get(i));
				}
				towers = null;
			}
			if (players != null) {
				for (String ag : players) {
					removeObsPropertyByTemplate("player", ag);
				}
				players.clear();
			}
			ObsProperty prop = getObsProperty("towers");
			if (prop != null) {
				prop.updateValue(0);
			} else {
				defineObsProperty("towers", 0);
			}
			prop = getObsProperty("round");
			if (prop != null)
				removeObsProperty("round");
		} else {
			defineObsProperty("violation", getCurrentOpAgentId().getAgentName(), "Bad call reset");
		}
	}

	@OPERATION
	void setAmountTowers(int totalTowers) {
		if (getCurrentOpAgentId().getAgentName().equals("judge")) {
			towers = new ArrayList<Integer>(totalTowers+1);
			for (int i = 0; i <= totalTowers; i++) {
				towers.add(0);
			}
			if (printlogs)
				System.out.println("setAmountTowers called with " + totalTowers + " Size " + towers.size());
			ObsProperty prop = getObsProperty("towers");
			prop.updateValue(totalTowers);
		} else {
			defineObsProperty("violation", getCurrentOpAgentId().getAgentName(), "Bad call setAmountTowers");
		}
	}

	@OPERATION
	void setAmountStonesTower(int idTower, int stones) {
		if (getCurrentOpAgentId().getAgentName().equals("judge")) {
			if (printlogs)
				System.out.println("setAmountStonesTower called with " + idTower + " " + stones);
			towers.set(idTower, stones);
			defineObsProperty("tower",idTower,stones);
		} else {
			defineObsProperty("violation", getCurrentOpAgentId().getAgentName(), "Bad call setAmountStones");
		}
	}

	@OPERATION
	void addPlayer(String agPlayer) {
		if (getCurrentOpAgentId().getAgentName().equals("judge")) {
			if (printlogs)
				System.out.println("addPlayer called with " + agPlayer);
			players.add(agPlayer);
			defineObsProperty("player", agPlayer);
		} else {
			defineObsProperty("violation", getCurrentOpAgentId().getAgentName(), "Bad call addPlayer");
		}
	}

	@OPERATION
	void play(int idTower, int stonesToRemove) {
		if (gameStatus == 0) return;
		if (getCurrentOpAgentId().getAgentName().equals(players.get(curPlayerId))) {
			if (idTower == 0 || idTower >= towers.size() || stonesToRemove == 0 || stonesToRemove > towers.get(idTower)) {
				defineObsProperty("violation", getCurrentOpAgentId().getAgentName(), "Bad call play: invalid parameters");
			} else {
				System.out.println("Agent " + getCurrentOpAgentId().getAgentName() + " played on tower " + idTower + " remove " + stonesToRemove);

				ObsProperty prop = getObsPropertyByTemplate("tower", idTower, towers.get(idTower));
				towers.set(idTower, towers.get(idTower)-stonesToRemove);
				prop.updateValues(idTower,towers.get(idTower));

				boolean hasNonZero = false;
				for (int i = 1; i < towers.size(); i++) {
					if (towers.get(i) > 0) {
						hasNonZero = true;
						break;
					}
				}
				if (hasNonZero) { //Game has no winner yet
					prop = getObsProperty("round");
					int newRound = prop.intValue()+1;
					curPlayerId = (curPlayerId+1)%players.size();
					printMesa(newRound);
					prop.updateValues(newRound,players.get(curPlayerId));
				}

			}
		} else {
			defineObsProperty("violation", getCurrentOpAgentId().getAgentName(), "Bad call play");
		}
	}

	@OPERATION
	void startGame() {
		if (getCurrentOpAgentId().getAgentName().equals("judge")) {
			gameStatus = 1;
			signal("start");
			curPlayerId = 0;
			printMesa(0);
			await_time(3000);
			defineObsProperty("round", 0, players.get(0));
		} else {
			defineObsProperty("violation", getCurrentOpAgentId().getAgentName(), "Bad call startGame");
		}
	}

	void printMesa(int round) {
		System.out.println();
		System.out.println("@ Current round " + round + " Player " + players.get(curPlayerId));
		System.out.println("Mesa: ");
		for (int i = 1; i < towers.size(); i++) {
			System.out.print("tower(" + i + ", " + towers.get(i) + ") ");
		}
		System.out.println();
	}
}

