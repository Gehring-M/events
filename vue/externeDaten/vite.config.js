import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
    plugins: [vue()],
    build: {
        outDir: 'C:/Projects/kulturbezirk/events/js/bundles',
        lib: {
            entry: './src/main.js',
            name: 'Geodatenimport',
            fileName: 'geodatenimport',
            formats: ['umd']
        },
        rollupOptions: {
            external: ['vue'],
            output: {
                globals: {
                    vue: 'Vue'
                },
                assetFileNames: (assetInfo) => {
                    // Exclude favicon from bundle
                    if (assetInfo.name === 'favicon.ico') {
                        return false;
                    }
                    return assetInfo.name;
                }
            }
        },
        cssCodeSplit: false
    }
})