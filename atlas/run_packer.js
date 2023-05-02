var fs = require('fs');
var path = require('path');
var texturePacker = require("free-tex-packer-core");
var glob = require("glob");

function process_sheet(name) {

  // See: https://github.com/odrick/free-tex-packer-core#available-options
  var options = {
    textureName: `${ name }`,
    width: 4096,
    height: 4096,
    fixedSize: false,
    powerOfTwo: true,
    padding: 2,
    extrude: 1,
    allowRotation: false,
    detectIdentical: true,
    allowTrim: true,
    exporter: "Pixi",
    removeFileExtension: true,
    prependFolderName: true
  };

  let glob_opts = {};
  glob("atlas_src/"+name+"/**/*.png", glob_opts, function(er, files) {
    console.log('Processing images for '+name);
    if (er) throw er;
    let images = [];
    for (img_path of files) {
      // Remove the prefix: src/{atlas_name}/
      let prefix_strip = new RegExp(`src/${ name }/`);
      let img_name = img_path.replace(prefix_strip, "");
      console.log(` - image ${ img_path } --> ${ img_name }`);
      images.push({path: img_name, contents: fs.readFileSync(img_path)});
    }
    console.log(`Generating dist/${ name }.png / json`);
    texturePacker(images, options, (files, error) => {
      if (error) {
        console.error('Packaging failed', error);
      } else {  
        for(let item of files) {
          fs.writeFileSync(path.join("dist", item.name.toString()), item.buffer);
        }
      }
    });

  });
}

// Glob the dirs
glob("atlas_src/*", { mark: true }, function(er, files) {
  let sheet_names = [];
  for (f of files) {
    if (f.match(/src\/(\w+)\/$/)) { // is a directory, trailing slash
      sheet_names.push(RegExp.$1);
    }
  }
  for (name of sheet_names) process_sheet(name);
});
