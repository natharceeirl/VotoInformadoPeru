/**
 * Netlify serverless function — CORS proxy for JNE candidate photos.
 * Fetches the image server-side (no CORS restriction) and returns it
 * with Access-Control-Allow-Origin: * so Flutter Web can display it.
 *
 * Endpoint: /.netlify/functions/foto-proxy?guidFoto={uuid}
 */

exports.handler = async function (event) {
  // Handle CORS preflight
  if (event.httpMethod === 'OPTIONS') {
    return {
      statusCode: 204,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type',
      },
      body: '',
    };
  }

  const guidFoto = event.queryStringParameters?.guidFoto;

  if (!guidFoto) {
    return {
      statusCode: 400,
      headers: { 'Access-Control-Allow-Origin': '*' },
      body: 'Missing guidFoto parameter',
    };
  }

  // Validate: guidFoto should look like a UUID (basic sanity check)
  const uuidRegex =
    /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
  if (!uuidRegex.test(guidFoto)) {
    return {
      statusCode: 400,
      headers: { 'Access-Control-Allow-Origin': '*' },
      body: 'Invalid guidFoto format',
    };
  }

  const upstreamUrl = `https://votoinformado.jne.gob.pe/VotoInformado/Informacion/GetFoto?guidFoto=${guidFoto}`;

  try {
    const response = await fetch(upstreamUrl, {
      headers: {
        'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        Accept: 'image/jpeg,image/png,image/*,*/*',
      },
    });

    if (!response.ok) {
      return {
        statusCode: response.status,
        headers: { 'Access-Control-Allow-Origin': '*' },
        body: `Upstream returned ${response.status}`,
      };
    }

    const buffer = Buffer.from(await response.arrayBuffer());
    const contentType =
      response.headers.get('content-type') || 'image/jpeg';

    return {
      statusCode: 200,
      headers: {
        'Content-Type': contentType,
        'Access-Control-Allow-Origin': '*',
        'Cache-Control': 'public, max-age=604800', // 7 days
      },
      body: buffer.toString('base64'),
      isBase64Encoded: true,
    };
  } catch (err) {
    return {
      statusCode: 502,
      headers: { 'Access-Control-Allow-Origin': '*' },
      body: `Failed to fetch photo: ${err.message}`,
    };
  }
};
