import * as vscode from 'vscode';
import * as fuzzy from 'fuzzy'; // You're importing fuzzy, but not using it.  Remove if not needed.
import * as fs from 'fs/promises';
import * as path from 'path';

interface MyQuickPickItem extends vscode.QuickPickItem {
    path: string;
    isFolder?: boolean;
}

export function activate(context: vscode.ExtensionContext) {

    let disposable = vscode.commands.registerCommand('fuzzy-finder.find', async () => {
        const workspaceFolders = vscode.workspace.workspaceFolders;

        if (!workspaceFolders || workspaceFolders.length === 0) {
            vscode.window.showInformationMessage('No workspace folder open.');
            return;
        }

        const items: MyQuickPickItem[] = [];

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
                        label: relativePath + '/', // Add slash for folders
                        description: folder.name + " (folder)",
                        path: folderPath,
                        isFolder: true
                    });
                });

            } catch (err) {
                vscode.window.showErrorMessage(`Error processing folder ${folder.name}: ${err}`);
                console.error("Error processing folder:", err);
            }
        }

        const pickedItem = await vscode.window.showQuickPick(items, {
            matchOnDescription: true,
            placeHolder: 'Fuzzy find file or folder...',
            ignoreFocusOut: true
        }) as MyQuickPickItem | undefined;

        if (pickedItem) {
            try {
                if (pickedItem.isFolder) {
                    vscode.commands.executeCommand('vscode.openFolder', vscode.Uri.file(pickedItem.path));
                } else {
                    const document = await vscode.workspace.openTextDocument(vscode.Uri.file(pickedItem.path));
                    vscode.window.showTextDocument(document);
                }
            } catch (err) {
                vscode.window.showErrorMessage(`Error opening ${pickedItem.label}: ${err}`);
                console.error("Error opening item:", err);
            }
        }
    });

    context.subscriptions.push(disposable);
}

async function getSubfolders(folderPath: string, basePath: string): Promise<string[]> {
    try {
        const entries = await fs.readdir(folderPath, { withFileTypes: true });
        const subfolders: string[] = [];

        for (const entry of entries) {
            const fullPath = path.join(folderPath, entry.name);
            if (entry.isDirectory()) {
                subfolders.push(fullPath);
                const nestedSubfolders = await getSubfolders(fullPath, basePath); // Pass basePath
                subfolders.push(...nestedSubfolders);
            }
        }
        return subfolders;
    } catch (err) {
        console.error("Error reading folder:", err);
        return [];
    }
}

export function deactivate() { }