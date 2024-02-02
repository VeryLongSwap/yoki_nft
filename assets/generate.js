const fs = require('fs');

// 画像の基本URL
const imageUrlBase = 'https://gateway.irys.xyz/-sjJpE3iTlWi8wkJzfjCrkMjHjSZCNIuZxxrpsYpdJQ/';

// JSONファイルの出力先ディレクトリ
const outputDirectory = './output';

// JSONファイルの枚数
const numberOfFiles = 30000;

// 1から115までのランダムな整数を取得する関数
const getRandomImageNumber = () => Math.floor(Math.random() * 115) + 1;

// JSONデータを生成する関数
const generateJsonData = () => {
  const imageNumber = getRandomImageNumber();
  return {
    name: 'Yoki x VLS',
    description: 'Yoki collabs Very Long Swap',
    image: `${imageUrlBase}${imageNumber}.png`,
  };
};

// ファイル書き込みの非同期関数
const writeFileAsync = (filePath, data) => {
  return new Promise((resolve, reject) => {
    fs.writeFile(filePath, data, 'utf8', (err) => {
      if (err) {
        reject(err);
      } else {
        resolve();
      }
    });
  });
};

// メイン処理
(async () => {
  try {
    // 出力先ディレクトリが存在しない場合は作成
    if (!fs.existsSync(outputDirectory)) {
      fs.mkdirSync(outputDirectory);
    }

    // 3万回繰り返してJSONファイルを生成
    for (let i = 0; i < numberOfFiles; i++) {
      const jsonData = generateJsonData();
      const fileName = `${i + 1}.json`;
      const filePath = `${outputDirectory}/${fileName}`;
      await writeFileAsync(filePath, JSON.stringify(jsonData, null, 2));
    }

    console.log(`${numberOfFiles} JSON files generated successfully in ${outputDirectory}`);
  } catch (error) {
    console.error('Error generating JSON files:', error);
  }
})();
