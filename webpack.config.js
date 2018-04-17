const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const path = require('path');

module.exports = {
  entry: './src_assets/js/index.js',
  output: {
    filename: 'js/bundle.js',
    path: path.resolve(__dirname, 'priv/static')
  },

  devServer: {
    headers: {
      "Access-Control-Allow-Origin": "*",
    }
  },

  module: {
    rules: [{
      test: /\.css$/,
      use: [
        MiniCssExtractPlugin.loader,
        "css-loader",
        'postcss-loader'
      ]
    }]
  },
  plugins: [
    new MiniCssExtractPlugin({
      filename: "css/index.css"
    })
  ]
};