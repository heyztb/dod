import 'dotenv/config';
import { spawn } from 'child_process';

const tunnel = spawn('cloudflared', [
	'tunnel',
	'run',
	'--token',
	process.env.CF_TUNNEL_KEY as string
]);

tunnel.stdout.on('data', (data) => {
	console.log(data.toString());
});

tunnel.stderr.on('data', (data) => {
	console.error(data.toString());
});

tunnel.on('close', (code) => {
	console.log(`Cloudflared tunnel closed with code ${code}`);
});
