import { Button } from "@/components/ui/button";
import { createFileRoute } from "@tanstack/react-router";
import { useState } from "react";

export const Route = createFileRoute("/play")({
  component: Play,
});

type DiceValue = 1 | 2 | 3 | 4 | 5 | 6;
type DiceState = {
  value: DiceValue;
  selected: boolean;
  locked: boolean;
};

type Player = {
  name: string;
  score: number;
};

function Play() {
  const [players] = useState<Player[]>([
    { name: "PLAYER 1", score: 0 },
    { name: "PLAYER 2", score: 0 },
    { name: "PLAYER 3", score: 0 },
    { name: "PLAYER 4", score: 0 },
  ]);
  const [currentPlayer, setCurrentPlayer] = useState(0);
  const [dice, setDice] = useState<DiceState[]>([
    { value: 1, selected: false, locked: false },
    { value: 1, selected: false, locked: false },
    { value: 1, selected: false, locked: false },
    { value: 1, selected: false, locked: false },
    { value: 1, selected: false, locked: false },
    { value: 1, selected: false, locked: false },
  ]);
  const [turnScore, setTurnScore] = useState(0);
  const [hasRolled, setHasRolled] = useState(false);

  const rollDice = () => {
    setDice(
      dice.map((die) =>
        die.locked
          ? die
          : {
              ...die,
              value: (Math.floor(Math.random() * 6) + 1) as DiceValue,
              selected: false,
            }
      )
    );
    setHasRolled(true);
  };

  const toggleDice = (index: number) => {
    if (!hasRolled || dice[index].locked) return;
    setDice(
      dice.map((die, i) =>
        i === index ? { ...die, selected: !die.selected } : die
      )
    );
  };

  const bankScore = () => {
    // Lock selected dice and add to turn score
    const selectedDice = dice.filter((d) => d.selected);
    if (selectedDice.length === 0) return;

    setDice(
      dice.map((die) =>
        die.selected ? { ...die, locked: true, selected: false } : die
      )
    );
    // Simple scoring logic (can be expanded)
    const score = selectedDice.reduce(
      (acc, die) => acc + (die.value === 1 ? 100 : die.value === 5 ? 50 : 0),
      0
    );
    setTurnScore(turnScore + score);
  };

  const endTurn = () => {
    // Bank turn score to player's total
    setCurrentPlayer((currentPlayer + 1) % players.length);
    setTurnScore(0);
    setDice(dice.map((die) => ({ ...die, selected: false, locked: false })));
    setHasRolled(false);
  };

  const activeDiceCount = dice.filter((d) => !d.locked).length;
  return (
    <div className="min-h-screen pb-24 font-mono">
      {/* Players Score Bar */}
      <div className="grid grid-cols-4 border-b-2 border-t-2 border-black">
        {players.map((player, index) => (
          <div
            key={index}
            className={`p-3 border-r-2 border-black last:border-r-0 ${
              index === currentPlayer ? "bg-black text-white" : ""
            }`}
          >
            <div className="text-xs font-bold">{player.name}</div>
            <div className="text-xl font-bold">{player.score}</div>
          </div>
        ))}
      </div>

      {/* Turn Score */}
      <div className="p-6 border-b-2 border-black">
        <div className="text-sm text-neutral-800">TURN SCORE</div>
        <div className="text-5xl font-bold">{turnScore}</div>
      </div>

      {/* Dice Grid */}
      <div className="p-6">
        <div className="grid grid-cols-3 gap-4 max-w-sm mx-auto">
          {dice.map((die, index) => (
            <button
              key={index}
              onClick={() => toggleDice(index)}
              disabled={!hasRolled || die.locked}
              className={`aspect-square border-4 flex items-center justify-center text-5xl font-bold transition-all ${
                die.locked
                  ? "border-gray-700 text-gray-700 cursor-not-allowed"
                  : die.selected
                    ? "border-black bg-black text-white"
                    : "border-black text-black hover:bg-black hover:text-white"
              }`}
            >
              {die.value}
            </button>
          ))}
        </div>
      </div>

      {/* Action Buttons */}
      <div className="p-4 space-y-3">
        <Button
          onClick={rollDice}
          disabled={activeDiceCount === 0}
          className="w-full h-16 text-xl font-bold bg-black text-white disabled:bg-gray-800 disabled:text-gray-600 disabled:cursor-not-allowed"
        >
          {hasRolled ? `ROLL AGAIN (${activeDiceCount})` : "ROLL DICE"}
        </Button>

        <div className="grid grid-cols-2 gap-3">
          <Button
            onClick={bankScore}
            disabled={!hasRolled || dice.every((d) => !d.selected)}
            className="h-14 text-lg font-bold border-2 border-black text-black disabled:border-gray-800 disabled:text-gray-600 disabled:cursor-not-allowed"
          >
            BANK
          </Button>
          <Button
            onClick={endTurn}
            disabled={turnScore === 0}
            className="h-14 text-lg font-bold border-2 border-black text-black disabled:border-gray-800 disabled:text-gray-600 disabled:cursor-not-allowed"
          >
            END TURN
          </Button>
        </div>
      </div>
    </div>
  );
}
