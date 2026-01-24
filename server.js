app.listen(process.env.PORT || 8080, ()=>console.log('Emobies live on', process.env.PORT)
const express = require('express');
const cors = require('cors');
const app = express();
const port = process.env.PORT || 8080;

app.use(cors());
app.use(express.json());

app.get('/health', (req, res) => res.json({status: 'OK'}));

app.listen(port, () => console.log('Emobies live on', port));
