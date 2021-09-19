// Bootstrap
import "css/site";
import "jquery";
import "popper.js";
import "bootstrap";
import "@fortawesome/fontawesome-free/css/all";

// Rails UJS
import Rails from "@rails/ujs";
Rails.start();

// Stimulus Reflex
import { Application } from "stimulus";
import { definitionsFromContext } from "stimulus/webpack-helpers";
import StimulusReflex from "stimulus_reflex";
import consumer from "../channels/consumer";

// Stimulus Reflex start
const application = Application.start();
const context = require.context("controllers", true, /_controller\.js$/);
application.load(definitionsFromContext(context));
application.consumer = consumer;
StimulusReflex.initialize(application, { consumer });

// Timeago
import "scripts/timeago";
