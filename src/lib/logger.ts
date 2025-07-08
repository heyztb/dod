import adze, { setup } from 'adze';
import { randomUUID } from 'crypto';

setup({
    meta: {
        requestId: randomUUID()
    }
});

const logger = adze.timestamp.timeNow.seal();
export default logger;
