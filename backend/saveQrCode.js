const fs = require('fs');

const base64Data = "iVBORw0KGgoAAAANSUhEUgAAAIQAAACECAYAAABRRIOnAAAAAklEQVR4AewaftIAAANzSURBVO3BQY5bCRYDwcwH3f/KHC96wdUHBKncHjcjzC/M/OOYKcdMOWbKMVOOmXLMlGOmHDPlmCnHTDlmyjFTjplyzJRjprz4kMrvlIR3qLQkNJUnSXii0pLQVH6nJHzimCnHTDlmyosvS8I3qbxD5YnKkyQ8UflEEr5J5ZuOmXLMlGOmvPhhKu9IwjtUPpGEf5PKO5Lwk46ZcsyUY6a8+I9TaUl4RxL+JsdMOWbKMVNe/Mckoak0lZaE/5Jjphwz5ZgpL35YEn6nJHyTyk9Kwp/kmCnHTDlmyosvU/mTqLQkPElCU2lJaCotCU9U/mTHTDlmyjFTXnwoCX+yJLxDpSWhqbQkPEnC/5Njphwz5Zgp5hc+oNKS0FS+KQlPVJ4k4YnKO5LwROWbkvCTjplyzJRjprz4wyXhHUloKk2lJeFJEppKU2lJaEl4otKS8ESlJeGbjplyzJRjpphf+CKVloQnKi0JTeUnJeETKi0Jn1BpSWgqT5LwiWOmHDPlmCkvPqTSktBUPpGEpvKTVFoSmkpLwhOVloQnSXiShKbyTcdMOWbKMVNefJnKO5LQVJ4k4YnKkyQ0lZaEpvJvUvmdjplyzJRjprz4siQ0lScqLQnvUGlJaCqfSMI7VD6h0pLQVFoSvumYKcdMOWbKiz+cypMkNJWWhHeotCQ0lZaET6h8QqUl4RPHTDlmyjFTXvxmSXhHEt6RhCcqLQlN5R0qn0hCU3mShKbyTcdMOWbKMVNe/GYqT5LQVL4pCU2lJaGptCQ0lXeovEOlJaEl4ZuOmXLMlGOmmF/4P6bSktBUniThHSpPkvAOlSdJ+J2OmXLMlGOmvPiQyu+UhJaEptKS8ESlJaGpfEKlJeETKk+S8Iljphwz5ZgpL74sCd+k8kSlJeGJSktCU2lJaCrvSMInVFoSmso3HTPlmCnHTHnxw1TekYR/UxKayjtUvikJTeUnHTPlmCnHTHnxl1NpSXii8iQJ71B5RxKaSktCU/mmY6YcM+WYKS/+ckl4otKS8ESlJeFvcsyUY6YcM+XFD0vCT0rCE5V3qLQkfCIJTeVPdsyUY6YcM+XFl6n8TiotCS0JTeVJEppKS8I7VJ4koak8UflJx0w5ZsoxU8wvzPzjmCnHTDlmyjFTjplyzJRjphwz5Zgpx0w5ZsoxU46ZcsyUY6b8D91QbjGjjQsgAAAAAElFTkSuQmCC";

// Remove the data URL scheme if it's included
const base64Image = base64Data.replace(/^data:image\/\w+;base64,/, "");
const buffer = Buffer.from(base64Image, 'base64');

fs.writeFile('qr_code.png', buffer, (err) => {
  if (err) {
    console.error('Error saving the QR code image:', err);
  } else {
    console.log('QR code image saved successfully as qr_code.png');
  }
});
