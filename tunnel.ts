import 'dotenv/config';
import { spawn } from 'child_process';

// To get a Cloudflare tunnel key:
// 1. Go to your Cloudflare dashboard.
// 2. Navigate to Zero Trust -> Access -> Tunnels.
// 3. Create a new tunnel or select an existing one.
// 4. The token will be displayed in the "Install and run a connector" section.
//    It's part of the `cloudflared service install <TOKEN>` command.
// 5. Store this token in your .env file as CF_TUNNEL_KEY.
const tunnel = spawn('cloudflared', [
	'tunnel',
	'run',
	'--token',
	process.env.CF_TUNNEL_KEY as string
]);

console.log('cloudflared tunnel started');
tunnel.on('close', (code) => {
	console.log(`cloudflared tunnel closed with code ${code}`);
});
