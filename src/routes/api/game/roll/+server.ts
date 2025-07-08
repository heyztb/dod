import { db } from '$lib/server/db';
import * as schema from '$lib/server/db/schema';
import { keccak_256 } from '@noble/hashes/sha3';
import { json, type RequestEvent } from '@sveltejs/kit';
import { eq } from 'drizzle-orm';

export const POST = async ({ request, locals }: RequestEvent) => {
	const { num_dice } = await request.json();
	const { user, session } = locals;
	if (!user || !session) {
		return json({ success: false, error: 'unauthorized' }, { status: 403 });
	}
	const player = db
		.select()
		.from(schema.player)
		.where(eq(schema.player.user_id, user.id))
		.limit(1)
		.get();
	if (!player) {
		return json({ success: false, error: 'unauthorized' }, { status: 403 });
	}
	const gameId = player.game_id;
	const game = db.select().from(schema.game).where(eq(schema.game.id, gameId)).limit(1).get();
	if (!game) {
		return json({ success: false, error: 'unauthorized' }, { status: 403 });
	}
	let current_hash = game.current_hash;
	let i = 0;
	const rolls = [];
	while (i != num_dice) {
		current_hash = keccak_256(current_hash).toString();
		rolls.push((parseInt(current_hash, 16) % 6) + 1);
		i++;
	}

	return json({ success: true, game: gameId });
};
