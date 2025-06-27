import { type Handle, type ServerInit } from '@sveltejs/kit';
import { sequence } from '@sveltejs/kit/hooks';
import { configure, getConsoleSink, getLogger } from '@logtape/logtape';
import { getFileSink } from '@logtape/file';
import { redactByField } from '@logtape/redaction';
import { randomUUID } from 'crypto';
import { getDomainFromUrl } from '$lib';
import { createClient } from '@farcaster/quick-auth';

export const init: ServerInit = async () => {
    await configure({
        sinks: {
            console: redactByField(
                getConsoleSink({
                    formatter: (record) => {
                        return [
                            new Date(record.timestamp).toISOString(),
                            record.level,
                            record.category,
                            record.rawMessage,
                            ...Object.entries(record.properties).map(
                                ([key, value]) => `${key}=${value}`
                            )
                        ].join(' ');
                    }
                }),
                {
                    fieldPatterns: [/token/i],
                    action: () => '***'
                }
            ),
            file: redactByField(
                getFileSink('log.jsonl', {
                    formatter: (record) => {
                        const ret = {
                            level: record.level,
                            timestamp: new Date(record.timestamp).toISOString(),
                            message: record.rawMessage,
                            ...record.properties
                        };
                        return JSON.stringify(ret) + '\n';
                    }
                }),
                {
                    fieldPatterns: [/token/i],
                    action: () => '***'
                }
            )
        },
        loggers: [
            {
                category: 'frontend',
                lowestLevel: 'debug',
                sinks: ['console']
            },
            {
                category: 'backend',
                lowestLevel: 'debug',
                sinks: ['console', 'file']
            }
        ],
        reset: true
    });
};

const logger = getLogger(['backend', 'auth']);

const auth = (): Handle => {
    return async ({ event, resolve }) => {
        const token = event.cookies.get('dod.ztb.dev-session-token');
        if (token) {
            logger.debug('validating session', {
                requestId: event.locals.requestId
            });
            // Verify the JWT token with Farcaster Quick Auth
            const client = createClient();
            const domain = getDomainFromUrl(event.request.url);

            logger.debug('Verifying Quick Auth token', { domain });

            const payload = await client.verifyJwt({
                token,
                domain
            });

            logger.debug('token', {
                token
            });
            logger.debug('Quick auth verification successful', {
                fid: payload.sub,
                address: payload.address
            });
        }
        return resolve(event);
    };
};

const id = (): Handle => {
    return async ({ event, resolve }) => {
        const id = randomUUID();
        event.locals.requestId = id;
        const response = await resolve(event);
        response.headers.set('x-request-id', id);
        return response;
    };
};

export const handle = sequence(id(), auth());
