// Web support for the barcode_scanner_poc plugin.
// This file is loaded automatically by the package.
window.startHtml5Qrcode = function(elementId, onSuccess, onError) {
  const html5QrCode = new Html5Qrcode(elementId);
  html5QrCode.start(
    { facingMode: "environment" },
    {
      fps: 60,
    },
    (decodedText, decodedResult) => {
      if (onSuccess) {
        onSuccess(decodedText);
      }
      html5QrCode.stop();
    },
    (errorMessage) => {
      if (onError) {
        onError(errorMessage);
      }
    }
  );
};
