import { json, type RequestEvent } from '@sveltejs/kit';
import { keccak_256 } from '@noble/hashes/sha3';
import { db } from '$lib/server/db';
import { game as game_table } from '$lib/server/db/schema';
import { eq } from 'drizzle-orm';
import { isAddress } from 'viem';
import { randomBytes } from '@noble/hashes/utils';

export const POST = async ({ request }: RequestEvent) => {
	const { room } = await request.json();

	const game = db.select().from(game_table).where(eq(game_table.room, room)).limit(1).get();
	if (game) {
		return json({ success: false, error: 'Game already exists' }, { status: 400 });
	}

	if (!isAddress(room)) {
		return json({ success: false, error: 'room must be valid address' });
	}

	const seed = randomBytes(32).toString();
	const commit = keccak_256(seed).toString();

	db.insert(game_table)
		.values({
			room,
			seed,
			commit,
			current_hash: commit
		})
		.run();

	// TODO: commit on the smart contract as well

	return json({ success: true, commit });
};
