const s3 = require('../config/awsConfig');

exports.uploadFile = (req, res) => {
  const params = {
    Bucket: process.env.S3_BUCKET,
    Key: req.file.originalname,
    Body: req.file.buffer,
  };

  s3.upload(params, (err, data) => {
    if (err) return res.status(500).send(err);
    res.json({ url: data.Location });
  });
};
