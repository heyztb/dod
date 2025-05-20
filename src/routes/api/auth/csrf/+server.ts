import { generateRandomString, type RandomReader } from '@oslojs/crypto/random';
import { json } from '@sveltejs/kit';

const random: RandomReader = {
	read: (array) => {
		return crypto.getRandomValues(array);
	}
};

export async function GET({ cookies }) {
	const nonce = generateRandomString(
		random,
		'0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ',
		32
	);
	cookies.set('dod.ztb.dev-csrf', nonce, {
		path: '/',
		httpOnly: true,
		secure: true,
		sameSite: 'none',
		expires: new Date(Date.now() + 1000 * 60 * 5) // 5 minutes
	});
	return json({ nonce });
}
