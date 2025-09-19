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
        Roll six dice to score points. First to 10,000, or highest score wins!
      </p>

      <div className="grid gap-6 md:grid-cols-2">
        <div>
          <h3 className="mb-3 text-xl font-semibold text-gray-900 dark:text-gray-100">
            How to Play
          </h3>
          <ul className="list-disc space-y-2 pl-5 text-gray-700 dark:text-gray-300">
            <li>Roll all six dice</li>
            <li>Set aside scoring dice</li>
            <li>Roll remaining dice or bank points</li>
            <li>No scoring dice = "Farkle" (lose turn points)</li>
            <li>Score all six dice = roll again</li>
            <li>
              After a player reaches 10,000 points, other players have one last
              turn to try to beat their score
            </li>
          </ul>
        </div>

        <div>
          <h3 className="mb-3 text-xl font-semibold text-gray-900 dark:text-gray-100">
            Scoring
          </h3>
          <ul className="list-disc space-y-1 pl-5 text-sm text-gray-700 dark:text-gray-300">
            <li>Single 1 = 100 points</li>
            <li>Single 5 = 50 points</li>
            <li>Three 1s = 1,000 points</li>
            <li>Three of a kind (2-6) = 100 × number</li>
            <li>Four of a kind = 1,000 points</li>
            <li>Five of a kind = 2,000 points</li>
            <li>Six of a kind = 3,000 points</li>
            <li>Straight (1-6) = 1,500 points</li>
            <li>Three pairs = 1,500 points</li>
            <li>Four of a kind + pair = 1,500 points</li>
            <li>Two three of a kinds = 2,500 points</li>
          </ul>
        </div>
      </div>
    </div>
  );
}
