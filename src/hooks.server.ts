import { validateSession } from '$lib/server/auth';
import { type Handle, type ServerInit } from '@sveltejs/kit';
import { sequence } from '@sveltejs/kit/hooks';
import { configure, getConsoleSink, getLogger } from '@logtape/logtape';
import { getFileSink } from '@logtape/file';
import { redactByField } from '@logtape/redaction';

export const init: ServerInit = async () => {
  await configure({
    sinks: {
      console: redactByField(getConsoleSink({
        formatter: (record) => {
          return [
            new Date(record.timestamp).toISOString(),
            record.level,
            record.category,
            record.rawMessage,
            ...Object.entries(record.properties).map(([key, value]) => `${key}=${value}`),
          ].join(' ')
        },
      }), {
        fieldPatterns: [/token/i],
        action: () => '***'
      }),
      file: redactByField(getFileSink('log.jsonl', {
        formatter: (record) => {
          const ret = {
            level: record.level,
            timestamp: new Date(record.timestamp).toISOString(),
            message: record.rawMessage,
            ...record.properties,
          }
          return JSON.stringify(ret) + '\n';
        },
      }), {
        fieldPatterns: [/token/i],
        action: () => '***'
      }),
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
    reset: true,
  });
};

const logger = getLogger(['backend', 'auth']);

const auth = (): Handle => {
  return async ({ event, resolve }) => {
    if (event.url.pathname.startsWith('/api/auth')) {
      return resolve(event)
    }
    const token = event.cookies.get('dod.ztb.dev-session-token');
    if (token) {
      logger.info('valdating session', {
        url: event.url.toString(),
      })
      const { session, user } = await validateSession(token);
      if (user && session) {
        event.locals.session = session;
        event.locals.user = user;
      }
    }
    return resolve(event);
  };
};

export const handle = sequence(auth());
