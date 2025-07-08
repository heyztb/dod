<script lang="ts">
	import { T } from '@threlte/core';
	import { OrbitControls, Text } from '@threlte/extras';

	const players = [
		{ name: 'Player 1', score: 100, status: 'Active' },
		{ name: 'Player 2', score: 85, status: 'Active' },
		{ name: 'Player 3', score: 120, status: 'Finished' },
		{ name: 'Player 4', score: 50, status: 'Waiting' }
	];
</script>

<div class="h-full w-full">
	<T.PerspectiveCamera makeDefault position={[0, 5, 10]} oncreate={(c) => c.lookAt(0, 0, 0)}>
		<OrbitControls enableZoom={true} enablePan={true} />
	</T.PerspectiveCamera>

	<T.AmbientLight intensity={0.5} />
	<T.DirectionalLight position={[10, 10, 5]} intensity={1} />

	<!-- Table -->
	<T.Group position={[0, -1, 0]}>
		<!-- Tabletop -->
		<T.Mesh position={[0, 1, 0]}>
			<T.BoxGeometry args={[10, 0.2, 5]} />
			<T.MeshStandardMaterial color="#8B4513" />
		</T.Mesh>

		<!-- Legs -->
		<T.Mesh position={[-4.5, 0, -2]}>
			<T.BoxGeometry args={[0.2, 2, 0.2]} />
			<T.MeshStandardMaterial color="#8B4513" />
		</T.Mesh>
		<T.Mesh position={[4.5, 0, -2]}>
			<T.BoxGeometry args={[0.2, 2, 0.2]} />
			<T.MeshStandardMaterial color="#8B4513" />
		</T.Mesh>
		<T.Mesh position={[-4.5, 0, 2]}>
			<T.BoxGeometry args={[0.2, 2, 0.2]} />
			<T.MeshStandardMaterial color="#8B4513" />
		</T.Mesh>
		<T.Mesh position={[4.5, 0, 2]}>
			<T.BoxGeometry args={[0.2, 2, 0.2]} />
			<T.MeshStandardMaterial color="#8B4513" />
		</T.Mesh>
	</T.Group>

	<!-- Data -->
	<T.Group position={[-4, 1.2, -1.5]}>
		<Text text="Player" anchorX="left" position={[0, 0, 0]} />
		<Text text="Score" anchorX="left" position={[4, 0, 0]} />
		<Text text="Status" anchorX="left" position={[8, 0, 0]} />

		{#each players as player, i (i)}
			<T.Group position={[0, -i * 0.5 - 0.5, 0]}>
				<Text text={player.name} anchorX="left" position={[0, 0, 0]} />
				<Text text={player.score.toString()} anchorX="left" position={[4, 0, 0]} />
				<Text text={player.status} anchorX="left" position={[8, 0, 0]} />
			</T.Group>
		{/each}
	</T.Group>
</div>
