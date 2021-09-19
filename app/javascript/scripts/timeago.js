import { start } from "@rails/ujs";
import { render, cancel } from "timeago.js";

const startTimeago = (event) => {
  const nodes = document.querySelectorAll(".timeago");

  // use render method to render nodes in real time
  if (nodes.length) render(nodes, "en_US");
};

document.addEventListener("cable-ready:after-morph", startTimeago);
document.addEventListener("DOMContentLoaded", startTimeago);
