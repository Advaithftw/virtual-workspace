const documents = {}; 

exports.getDocument = (req, res) => {
  const { roomCode } = req.params;
  const document = documents[roomCode] || { content: [] }; 
  res.json(document);
};

exports.saveDocument = (req, res) => {
  const { roomCode } = req.params;
  const { content } = req.body;

  if (!content) {
    return res.status(400).send({ error: 'Content is required' });
  }

  documents[roomCode] = { content };
  res.json({ message: 'Document saved successfully' });
};
