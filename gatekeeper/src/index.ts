import { sentry } from '@hono/sentry';
import { cors } from 'hono/cors';
import { Hono } from 'hono/tiny';

import { OauthClient } from './oauth-client';

/* eslint-disable @typescript-eslint/naming-convention */
export interface Env {
  ENVIRONMENT: 'dev' | 'staging' | 'production';
  SPOTIFY_CLIENT_ID: string;
  SPOTIFY_CLIENT_SECRET: string;
  WORKER_ROOT: string;
  APP_ROOT: string;
  SENTRY_DSN: string;
}
/* eslint-enable @typescript-eslint/naming-convention */

let spotifyClient: OauthClient | undefined = undefined;

async function getSpotifyClient(env: Env): Promise<OauthClient> {
  if (!spotifyClient) {
    spotifyClient = new OauthClient({
      issuer: 'https://accounts.spotify.com',
      clientId: env.SPOTIFY_CLIENT_ID,
      clientSecret: env.SPOTIFY_CLIENT_SECRET,
      grantRedirectURI: `${env.WORKER_ROOT}/spotify/authenticated`,
      scopes: [
        'playlist-read-collaborative',
        'playlist-read-private',
        'user-read-playback-state',
        'user-modify-playback-state',
        'user-read-email',
        'user-read-private',
        'streaming'
      ]
    });
    await spotifyClient.readServer();
  }

  return spotifyClient;
}

/* eslint-disable @typescript-eslint/naming-convention */
const app = new Hono<{
  Bindings: Env;
  Variables: {
    spotify: OauthClient;
  };
}>();
/* eslint-enable @typescript-eslint/naming-convention */

app.use(cors());
app.use((c, next) => sentry({ environment: c.env.ENVIRONMENT })(c, next));

app.use('/spotify/*', async (c, next) => {
  console.log('hello there');

  c.set('spotify', await getSpotifyClient(c.env));

  await next();
});

app.get('/spotify/login', async (c) => {
  const spotify = c.get('spotify');
  const loginUrl = await spotify.getAuthorizationURL();

  return c.redirect(loginUrl.toString());
});

app.get('/spotify/authenticated', async (c) => {
  const spotify = c.get('spotify');
  const result = await spotify.grantCode(c.req.url);
  const redirectUrl = new URL(`${c.env.APP_ROOT}/auth/spotify`);

  redirectUrl.searchParams.set('access_token', result.access_token);
  redirectUrl.searchParams.set('refresh_token', result.refresh_token as string);
  redirectUrl.searchParams.set('expires_in', result.expires_in?.toString() as string);

  return c.redirect(redirectUrl.toString());
});

app.get('/spotify/refresh', async (c) => {
  if (!c.req.query('token')) {
    return c.notFound();
  }

  const spotify = c.get('spotify');
  const result = await spotify.refresh(c.req.query('token') as string);

  return c.json(result);
});

app.get('/fail', () => {
  throw new Error('boom');
});

export default app;
