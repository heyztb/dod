<script lang="ts">
	// import { Canvas } from '@threlte/core';
	// import Game from '$lib/scenes/Game.svelte';
	import { onMount } from 'svelte';
	import DiceBox from '@3d-dice/dice-box';

	onMount(async () => {
		console.log('dice box mounting');
		const diceBox = new DiceBox('#diceBox', {
			assetPath: '/'
		});
		await diceBox.init();
	});
</script>

<div id="diceBox"></div>

<!-- <Canvas> -->
<!--     <Game /> -->
<!-- </Canvas> -->
