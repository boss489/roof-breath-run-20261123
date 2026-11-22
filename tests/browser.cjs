const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');
const root = path.join(__dirname, '..');
const out = path.join(root, 'evidence');
fs.mkdirSync(out, {recursive:true});
(async () => {
 const browser = await chromium.launch({headless:true, executablePath:'/Applications/Google Chrome.app/Contents/MacOS/Google Chrome', args:['--no-sandbox','--use-gl=angle','--use-angle=swiftshader']});
 for (const width of [960,320]) {
  const context = await browser.newContext({viewport:{width,height:640}, deviceScaleFactor:1, hasTouch:width===320, isMobile:width===320});
  const page = await context.newPage();
  const errors=[]; page.on('pageerror',e=>errors.push(e.message)); page.on('console',m=>{if(m.type()==='error') errors.push(m.text())});
  await page.goto('http://127.0.0.1:8765/',{waitUntil:'load'});
  await page.waitForTimeout(4500);
  console.log(width,'canvas',await page.locator('canvas').count(), 'canvas box', await page.locator('canvas').boundingBox());
  await page.screenshot({path:path.join(out,`${width}-title.png`)});
  await page.locator('canvas').click({position:{x:width/2,y:width===320?490:500}});
  await page.waitForTimeout(250);
  await page.screenshot({path:path.join(out,`${width}-tutorial.png`)});
  await page.locator('canvas').click({position:{x:width/2,y:width===320?490:500}});
  await page.waitForTimeout(300);
  await page.screenshot({path:path.join(out,`${width}-play.png`)});
  if(width===960){
    for(let i=0;i<3;i++){
      await page.keyboard.down('ArrowRight'); await page.waitForTimeout(1150); await page.keyboard.up('ArrowRight'); await page.waitForTimeout(300);
    }
    await page.screenshot({path:path.join(out,'960-failure.png')});
    await page.keyboard.press('Enter'); await page.waitForTimeout(300);
    await page.keyboard.down('Shift'); await page.keyboard.down('ArrowRight');
    await page.waitForTimeout(5800);
    await page.keyboard.up('ArrowRight'); await page.keyboard.up('Shift');
    await page.screenshot({path:path.join(out,'960-stage3-rest.png')});
    await page.waitForTimeout(1000);
    await page.keyboard.down('Shift'); await page.keyboard.down('ArrowRight');
    await page.waitForTimeout(2600);
    await page.keyboard.up('ArrowRight'); await page.keyboard.up('Shift');
    await page.screenshot({path:path.join(out,'960-success.png')});
  } else {
    await page.mouse.move(155, 585); await page.mouse.down(); await page.waitForTimeout(600); await page.mouse.up();
    await page.screenshot({path:path.join(out,'320-touch.png')});
    const cdp = await context.newCDPSession(page);
    await cdp.send('Input.dispatchTouchEvent',{type:'touchStart',touchPoints:[{x:155,y:585,id:1},{x:267,y:585,id:2}]});
    await page.waitForTimeout(1050);
    await cdp.send('Input.dispatchTouchEvent',{type:'touchEnd',touchPoints:[]});
    await page.screenshot({path:path.join(out,'320-multitouch-sprint.png')});
  }
  console.log(width,'errors',errors.slice(0,10));
  if(errors.some(e=>!e.includes('404'))) throw new Error(`${width} browser errors: ${errors.join('; ')}`);
  await context.close();
 }
 await browser.close();
})().catch(e=>{console.error(e); process.exit(1)});
