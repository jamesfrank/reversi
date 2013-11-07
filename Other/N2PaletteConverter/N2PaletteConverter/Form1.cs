using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace N2PaletteConverter
{
    public partial class Form1 : Form
    {
        const int width = 640;
        const int height = 480;
        Color[] palette;
        Byte[] byteArray = null;

        public Form1()
        {
            InitializeComponent();

            var paletteList = new List<Color>();
            for (int i = 0; i < 256; i++)
            {
                int r=0, g=0, b=0;
                if ((i & 0x01) != 0) r += 36;
                if ((i & 0x02) != 0) r += 73;
                if ((i & 0x04) != 0) r += 146;
                if ((i & 0x08) != 0) g += 36;
                if ((i & 0x10) != 0) g += 73;
                if ((i & 0x20) != 0) g += 146;
                if ((i & 0x40) != 0) b += 85;
                if ((i & 0x80) != 0) b += 170;
                paletteList.Add(Color.FromArgb(255, r, g, b));
            }
            palette = paletteList.ToArray();
        }

        private void btn_Load_IMG_Click(object sender, EventArgs e)
        {
            var fileDialog = new OpenFileDialog();
            fileDialog.ShowDialog();

            if(File.Exists(fileDialog.FileName))
            {
                try {
                    inPictureBox.Image = Image.FromFile(fileDialog.FileName);
                    ConvertImage();
                } catch(Exception excep) {
                    MessageBox.Show("Failure loading image: " + fileDialog.FileName + "\r\n" + excep.Message);
                }
            }
        }

        void ConvertImage()
        {
            var inBmp = new Bitmap(inPictureBox.Image);
            var inWidth = (inBmp.Width > width) ? width : inBmp.Width;
            var inHeight = (inBmp.Height > height) ? height : inBmp.Height;
            var outBmp = new Bitmap(inWidth, inHeight);

            var byteList = new List<byte>();
            for (int x = 0; x < inWidth; x++)
            {
                for (int y = 0; y < inHeight; y++)
                {
                    var pixel = ConvertFromColor(inBmp.GetPixel(x, y));
                    byteList.Add(pixel);
                    outBmp.SetPixel(x, y, ConvertToColor(pixel));
                }
            }
            byteArray = byteList.ToArray();
            outPictureBox.Image = outBmp;
        }

        byte ConvertFromColor(Color inColor)
        {
            var nearestColor = -1;
            var nearestDist = Double.MaxValue;
            for (var i = 0; i < palette.Length; i++)
            {
                var currentColor = palette[i];
                var dist_r = (int)currentColor.R - (int)inColor.R;
                var dist_g = (int)currentColor.G - (int)inColor.G;
                var dist_b = (int)currentColor.B - (int)inColor.B;
                var euclidean_dist = (dist_r * dist_r) + (dist_g * dist_g) + (dist_b * dist_b);
                if (nearestColor == -1 || euclidean_dist < nearestDist)
                {
                    nearestDist = euclidean_dist;
                    nearestColor = i;
                }
            }
            return (byte) nearestColor;
        }

        Color ConvertToColor(byte inByte)
        {
            return palette[inByte];
        }

        private void button3_Click(object sender, EventArgs e)
        {
            if (byteArray == null)
                MessageBox.Show("Must first load an image.");
            else
            {
                var fileDialog = new SaveFileDialog();
                fileDialog.ShowDialog();

                if (!String.IsNullOrWhiteSpace(fileDialog.FileName))
                {
                    if (File.Exists(fileDialog.FileName))
                        File.Delete(fileDialog.FileName);

                    var sb = new StringBuilder();
                    foreach (var currbyte in byteArray)
                        sb.Append(byteToHex(currbyte));

                    File.WriteAllText(fileDialog.FileName, sb.ToString());
                }
            }
        }

        string byteToHex(byte inByte)
        {
            return "" + "0123456789ABCDEF"[inByte / 16] +  "0123456789ABCDEF"[inByte & 0xF]; 
        }
    }
}
