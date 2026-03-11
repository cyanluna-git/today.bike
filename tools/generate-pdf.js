const puppeteer = require('puppeteer-core');
const path = require('path');

(async () => {
  const browser = await puppeteer.launch({
    executablePath: '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });

  const page = await browser.newPage();

  const htmlPath = 'file://' + path.resolve(__dirname, 'proposal.html');
  await page.goto(htmlPath, { waitUntil: 'networkidle0', timeout: 30000 });

  // 폰트 로딩 대기
  await new Promise(r => setTimeout(r, 2000));

  await page.pdf({
    path: 'proposal.pdf',
    format: 'A4',
    printBackground: true,
    margin: { top: 0, right: 0, bottom: 0, left: 0 }
  });

  await browser.close();
  console.log('✅ proposal.pdf 생성 완료');
})();
