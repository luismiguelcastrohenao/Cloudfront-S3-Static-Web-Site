import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  /* config options here */
  output: 'export',              // obliga la exportación estática
  //trailingSlash: true            // opcional: Change links `/me` -> `/me/` and emit `/me.html` -> `/me/index.html
};

export default nextConfig;
