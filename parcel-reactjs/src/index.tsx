import * as React from 'react';
import * as ReactDOM from "react-dom";

import App from './app';
import "./style.scss";

var mountNode = document.getElementById("app");
ReactDOM.render(<App name="Minecraft World" />, mountNode);
