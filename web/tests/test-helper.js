import Application from '@unidancing/app/app';
import config from '@unidancing/app/config/environment';
import * as QUnit from 'qunit';
import { setApplication } from '@ember/test-helpers';
import { setup } from 'qunit-dom';
import { start } from 'ember-qunit';
import setupSinon from 'ember-sinon-qunit';

setApplication(Application.create(config.APP));

setupSinon();

setup(QUnit.assert);

start();
