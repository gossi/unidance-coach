import './assets/app.css';

import Application from '@ember/application';

import config from '@unidancing/app/config/environment';
import loadInitializers from 'ember-load-initializers';
import Resolver from 'ember-resolver';

import '@hokulea/core/index.css';

export default class App extends Application {
  modulePrefix = config.modulePrefix;
  podModulePrefix = config.podModulePrefix;
  Resolver = Resolver;
}

loadInitializers(App, config.modulePrefix);
