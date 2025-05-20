import { validateSession } from '$lib/server/auth';
import { type Handle, type ServerInit } from '@sveltejs/kit';
import { sequence } from '@sveltejs/kit/hooks';
import { configure, getConsoleSink, getLogger } from '@logtape/logtape';

export const init: ServerInit = async () => {
  await configure({
    sinks: {
      console: getConsoleSink(),
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
        sinks: ['console']
      }
    ]
  });
};

const logger = getLogger(['backend', 'auth']);

const auth = (): Handle => {
  return async ({ event, resolve }) => {
    const token = event.cookies.get('dod.ztb.dev-session-token');
    if (token) {
      logger.info('Validating session', { token });
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
