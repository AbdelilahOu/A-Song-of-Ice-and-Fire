export type AssetUploadInput = {
  key: string;
  contentBase64: string;
  contentType: string;
};

function assertSafeKey(key: string) {
  if (!key || key.startsWith("/") || key.includes("..") || key.includes("\\")) {
    throw new Error("Asset key must be a relative R2 object key without '..'");
  }
}

function decodeBase64(contentBase64: string) {
  const binary = atob(contentBase64);
  const bytes = new Uint8Array(binary.length);
  for (let index = 0; index < binary.length; index += 1) {
    bytes[index] = binary.charCodeAt(index);
  }
  return bytes;
}

function assetUrl(assetBaseUrl: string, key: string) {
  const baseUrl = assetBaseUrl.replace(/\/$/, "");
  const encodedKey = key
    .split("/")
    .map((segment) => encodeURIComponent(segment))
    .join("/");
  return `${baseUrl}/${encodedKey}`;
}

export async function uploadAsset(bucket: R2Bucket, assetBaseUrl: string, input: AssetUploadInput) {
  assertSafeKey(input.key);
  const body = decodeBase64(input.contentBase64);
  await bucket.put(input.key, body, {
    httpMetadata: {
      contentType: input.contentType,
    },
  });

  return {
    key: input.key,
    contentType: input.contentType,
    size: body.byteLength,
    url: assetUrl(assetBaseUrl, input.key),
  };
}

export async function listAssets(
  bucket: R2Bucket,
  assetBaseUrl: string,
  prefix: string | undefined,
  cursor: string | undefined,
  limit: number,
) {
  const result = await bucket.list({
    prefix,
    cursor,
    limit: Math.min(Math.max(limit, 1), 500),
  });

  return {
    objects: result.objects.map((object) => ({
      key: object.key,
      size: object.size,
      uploaded: object.uploaded.toISOString(),
      etag: object.etag,
      url: assetUrl(assetBaseUrl, object.key),
    })),
    cursor: result.truncated ? result.cursor : undefined,
    truncated: result.truncated,
  };
}

export async function getAssetMetadata(bucket: R2Bucket, assetBaseUrl: string, key: string) {
  assertSafeKey(key);
  const object = await bucket.head(key);
  if (!object) {
    return null;
  }

  return {
    key: object.key,
    size: object.size,
    uploaded: object.uploaded.toISOString(),
    etag: object.etag,
    contentType: object.httpMetadata?.contentType,
    url: assetUrl(assetBaseUrl, object.key),
  };
}

export async function deleteAsset(bucket: R2Bucket, key: string) {
  assertSafeKey(key);
  await bucket.delete(key);
  return { deleted: true, key };
}
