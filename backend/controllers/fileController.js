const s3 = require('../config/awsConfig');

exports.uploadFile = (req, res) => {
  const params = {
    Bucket: process.env.S3_BUCKET,
    Key: req.file.originalname,
    Body: req.file.buffer,
  };

  s3.upload(params, (err, data) => {
    if (err) return res.status(500).send({ error: 'File upload failed', details: err });
    res.json({ message: 'File uploaded successfully', url: data.Location });
  });
};

exports.listFiles = (req, res) => {
  const params = {
    Bucket: process.env.S3_BUCKET,
  };

  s3.listObjects(params, (err, data) => {
    if (err) return res.status(500).send({ error: 'Failed to list files', details: err });
    const files = data.Contents.map((file) => ({
      key: file.Key,
      lastModified: file.LastModified,
      size: file.Size,
    }));
    res.json(files);
  });
};

exports.downloadFile = (req, res) => {
  const { key } = req.params;

  const params = {
    Bucket: process.env.S3_BUCKET,
    Key: key,
  };

  s3.getObject(params, (err, data) => {
    if (err) return res.status(500).send({ error: 'File download failed', details: err });

    res.attachment(key);
    res.send(data.Body);
  });
};
