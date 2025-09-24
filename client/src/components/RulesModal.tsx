export default function RulesModal() {
  return (
    <div className="space-y-6">
      <div className="aspect-video w-full overflow-hidden rounded-lg">
        <iframe
          src="https://www.youtube.com/embed/EvWcUDYB9wQ"
          title="How to Play Farkle"
          className="h-full w-full"
          allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
          allowFullScreen
        ></iframe>
      </div>

      <p className="text-lg text-gray-700 dark:text-gray-300">
        Roll dice to score points. First to 1,000, or highest score wins!
      </p>

      <div className="grid gap-6 md:grid-cols-2">
        <div>
          <h3 className="mb-3 text-xl font-semibold text-gray-900 dark:text-gray-100">
            How to Play
          </h3>
          <ul className="list-disc space-y-2 pl-5 text-gray-700 dark:text-gray-300">
            <li>Players start their turn with six dice</li>
            <li>Roll all six dice</li>
            <li>Set aside scoring dice</li>
            <li>Roll remaining dice or bank points</li>
            <li>No scoring dice = "Farkle" (lose turn points)</li>
            <li>Score all six dice = roll again</li>
            <li>
              After a player reaches 1,000 points, other players have one last
              turn to try to beat their score
            </li>
          </ul>
        </div>

        <div>
          <h3 className="mb-3 text-xl font-semibold text-gray-900 dark:text-gray-100">
            Scoring
          </h3>
          <ul className="list-disc space-y-1 pl-5 text-sm text-gray-700 dark:text-gray-300">
            <li>Single 1 = 10 points</li>
            <li>Single 5 = 5 points</li>
            <li>Three 1s = 1,00 points</li>
            <li>Three of a kind (2-6) = 10 × number</li>
            <li>Four of a kind = 100 points</li>
            <li>Five of a kind = 200 points</li>
            <li>Six of a kind = 300 points</li>
            <li>Straight (1-6) = 150 points</li>
            <li>Three pairs = 150 points</li>
            <li>Four of a kind + pair = 150 points</li>
            <li>Two three of a kinds = 250 points</li>
          </ul>
        </div>
      </div>
    </div>
  );
}
