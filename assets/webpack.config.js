const path = require('path');
const glob = require('glob');
const CopyWebpackPlugin = require('copy-webpack-plugin');
const MiniCSSExtractPlugin = require("mini-css-extract-plugin");
const OptimizeCSSAssetsPlugin = require('optimize-css-assets-webpack-plugin');
const ExtractTextPlugin = require('extract-text-webpack-plugin');
const TerserPlugin = require('terser-webpack-plugin');

module.exports = (env, options) => ({
    optimization: {
        minimizer: [
            new OptimizeCSSAssetsPlugin({}),
            new TerserPlugin({
                test: /app\.js$/,
                terserOptions: {
                    "compress": {
                        "pure_funcs": ["F1", "F2", "F3", "F4", "F5", "F6", "F6", "F8", "F9", "A2", "A3", "A4", "A5", "A6", "A7", "A8", "A9"],
                        "pure_getters": true,
                        "keep_fargs": false,
                        "unsafe_comps": true,
                        "unsafe": true,
                        "ecma": 6
                    }
                }
            })
        ]
    },
    entry: {
        app: './js/app.js',
    },
    output: {
        filename: '[name].js',
        path: path.resolve(__dirname, '../priv/static/js')
    },
    module: {
        rules: [
            {
                test: /\.js$/,
                exclude: /node_modules/,
                use: {
                    loader: 'babel-loader',
                    options: {
                        presets: ['@babel/preset-env']
                    }
                }
            },            
            {
                test: /\.(png|jpg|gif|svg|eot|ttf|woff2?(\?v=[0-9]\.[0-9]\.[0-9])?)$/,
                use: [
                    {
                        loader: 'file-loader'
                    }
                ]
            },      
            {
                test: /\.elm$/,
                exclude: [/elm-stuff/, /node_modules/],
                use: {
                    loader: 'elm-webpack-loader',
                    options: {
                        debug: options.mode === "development"
                    }
                }
            },
            {
                test: /\.css$/,
                use: ExtractTextPlugin.extract({
                    use: [
                        { loader: 'css-loader', options: { importLoaders: 1 } },
                        'postcss-loader',
                    ],
                }),
            }
        ]
    },
    plugins: [
        // Pulls out compile css to a standalone file
        new ExtractTextPlugin({
            filename: '../css/[name].css'
        }),
        new CopyWebpackPlugin([{ from: 'static/', to: '../' }]),
        new CopyWebpackPlugin([{ from: 'node_modules/@fortawesome/fontawesome-pro/webfonts/', to: '../webfonts' }]),
        new CopyWebpackPlugin([{ from: 'node_modules/@fortawesome/fontawesome-pro/css/all.min.css', to: '../css/fa.min.css' }]),
    ]
});
