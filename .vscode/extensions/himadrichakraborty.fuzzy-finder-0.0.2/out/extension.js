"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (k !== "default" && Object.prototype.hasOwnProperty.call(mod, k)) __createBinding(result, mod, k);
    __setModuleDefault(result, mod);
    return result;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.deactivate = exports.activate = void 0;
const vscode = __importStar(require("vscode"));
const fs = __importStar(require("fs/promises"));
const path = __importStar(require("path"));
function activate(context) {
    let disposable = vscode.commands.registerCommand('fuzzy-finder.find', async () => {
        const workspaceFolders = vscode.workspace.workspaceFolders;
        if (!workspaceFolders || workspaceFolders.length === 0) {
            vscode.window.showInformationMessage('No workspace folder open.');
            return;
        }
        const items = [];
        for (const folder of workspaceFolders) {
            try {
                const basePath = folder.uri.fsPath;
                const files = await vscode.workspace.findFiles('**/*');
                for (const file of files) {
                    const relativePath = path.relative(basePath, file.fsPath);
                    items.push({
                        label: relativePath,
                        description: folder.name,
                        path: file.fsPath
                    });
                }
                const folderItems = await getSubfolders(basePath, basePath); // Pass basePath
                folderItems.forEach(folderPath => {
                    const relativePath = path.relative(basePath, folderPath);
                    items.push({
                        label: relativePath + '/',
                        description: folder.name + " (folder)",
                        path: folderPath,
                        isFolder: true
                    });
                });
            }
            catch (err) {
                vscode.window.showErrorMessage(`Error processing folder ${folder.name}: ${err}`);
                console.error("Error processing folder:", err);
            }
        }
        const pickedItem = await vscode.window.showQuickPick(items, {
            matchOnDescription: true,
            placeHolder: 'Fuzzy find file or folder...',
            ignoreFocusOut: true
        });
        if (pickedItem) {
            try {
                if (pickedItem.isFolder) {
                    vscode.commands.executeCommand('vscode.openFolder', vscode.Uri.file(pickedItem.path));
                }
                else {
                    const document = await vscode.workspace.openTextDocument(vscode.Uri.file(pickedItem.path));
                    vscode.window.showTextDocument(document);
                }
            }
            catch (err) {
                vscode.window.showErrorMessage(`Error opening ${pickedItem.label}: ${err}`);
                console.error("Error opening item:", err);
            }
        }
    });
    context.subscriptions.push(disposable);
}
exports.activate = activate;
async function getSubfolders(folderPath, basePath) {
    try {
        const entries = await fs.readdir(folderPath, { withFileTypes: true });
        const subfolders = [];
        for (const entry of entries) {
            const fullPath = path.join(folderPath, entry.name);
            if (entry.isDirectory()) {
                subfolders.push(fullPath);
                const nestedSubfolders = await getSubfolders(fullPath, basePath); // Pass basePath
                subfolders.push(...nestedSubfolders);
            }
        }
        return subfolders;
    }
    catch (err) {
        console.error("Error reading folder:", err);
        return [];
    }
}
function deactivate() { }
exports.deactivate = deactivate;
