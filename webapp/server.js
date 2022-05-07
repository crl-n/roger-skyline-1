'use strict';

const express = require('express');
const path = require('path');

const PORT 80;
const HOST '10.11.203.111';

const app = express();

app.get('/', (req, res) => {
	res.sendFile(path.join(__dirname + '/login.html'));
});

app.listen(PORT, HOST);
console.log(`Running amazing web-app on http://${HOST}:${PORT}`);
