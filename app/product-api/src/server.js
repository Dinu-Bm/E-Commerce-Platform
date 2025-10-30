const express = require('express');
const app = express();

app.get('/health', (req, res) => res.status(200).send('OK'));
app.get('/products', (req, res) => {
  res.json([{ id: 1, name: 'Laptop' }, { id: 2, name: 'Headphones' }]);
});
app.get('/', (req, res) => res.send('E-Commerce Product API'));
const port = process.env.PORT || 3000;
app.listen(port, () => console.log(`API on ${port}`));
