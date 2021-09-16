import "css/site";
import "jquery";
import "popper.js";
import "bootstrap";
import "@fortawesome/fontawesome-free/css/all";

import Rails from '@rails/ujs';
Rails.start();

import { Application } from "stimulus";
import { definitionsFromContext } from "stimulus/webpack-helpers";
import StimulusReflex from "stimulus_reflex";
import consumer from "../channels/consumer";

const application = Application.start();
const context = require.context("controllers", true, /_controller\.js$/);
application.load(definitionsFromContext(context));
application.consumer = consumer;
StimulusReflex.initialize(application, { consumer });
