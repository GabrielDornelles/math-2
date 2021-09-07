### A Pluto.jl notebook ###
# v0.15.1

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ eaf44e44-0f51-11ec-1ad9-954ad43b66c8
begin
	import Pkg
	Pkg.activate(mktempdir())
	Pkg.add([
		Pkg.PackageSpec(name="ImageIO", version="0.5"),
		Pkg.PackageSpec(name="ImageShow", version="0.2"),
		Pkg.PackageSpec(name="FileIO", version="1.6"),
		Pkg.PackageSpec(name="PNGFiles", version="0.3.6"),
		Pkg.PackageSpec(name="ImageMagick", version="1"),
        Pkg.PackageSpec(name="ImageFiltering", version="0.6"),
		Pkg.PackageSpec(name="Colors", version="0.12"),
		Pkg.PackageSpec(name="ColorVectorSpace", version="0.8"),
			
		Pkg.PackageSpec(name="PlutoUI", version="0.7"),  
		Pkg.PackageSpec(name="Plots", version="1"),  
	])

	using Colors, ColorVectorSpace, ImageShow, FileIO
	using ImageFiltering
	using Plots, PlutoUI

	using Statistics, LinearAlgebra  # standard libraries available in any environment
end

# ╔═╡ 1575ce99-17fb-4b7b-834f-4bc4eed33053
md"""
# Loading images and using sliders
"""

# ╔═╡ d0d44648-0959-47aa-8553-e2c10e6dc948
rem = load("rem.png")

# ╔═╡ b4eae467-df6e-4d2a-8c40-2f1ed997fcd9
@bind range_rows RangeSlider(1:size(rem)[1])

# ╔═╡ d6529aa6-e680-4695-bcb9-00278b0d5687
@bind range_cols RangeSlider(1:size(rem)[2])

# ╔═╡ 1e034d75-3252-491d-b9ff-6219f8902179
rem[range_rows, range_cols]

# ╔═╡ 30278719-1c91-48e4-afd1-f227babdcde0
md"""
# Inverting the image with simple for loops and array comprehension
"""

# ╔═╡ 8847937f-78a7-4300-b252-5ae302a69d93
begin
	
	# naive implementation with simple for loops
	function invert(color_image)

		rows = size(color_image)[1]
		cols = size(color_image)[2]

		temp = copy(color_image)
		for i=1:rows
			for j=1:cols
				r = 1 - color_image[i,j].r
				g = 1 - color_image[i,j].g
				b = 1 - color_image[i,j].b 
				temp[i,j] = RGB(r,g,b)
			end
		end

		return temp
	end

	# kinda vectorized version using Array comprehensions, runs about 2x faster
	function invert_with_comprehension(color_image)
		temp = copy(color_image)
		rows = size(color_image)[1]
		cols = size(color_image)[2]
		temp = [RGB(1 - color_image[i,j].r, 1-color_image[i,j].g, 1-color_image[i,j].b) for i=1:rows, j=1:cols]
		return temp
	end
	
end

# ╔═╡ 6c904034-c1ec-4817-b66d-e8d5da1aaeb0
inverted_rem_naive = invert(rem)

# ╔═╡ a0bd4084-0a4f-4ec4-87d8-090c667fd720
inverted_rem_vectorized = invert_with_comprehension(rem)

# ╔═╡ 1efb1749-7a8c-4762-a130-7faf0ac772a8
md"""
# Edge detecting with sobel filter
"""

# ╔═╡ b89f6aee-94fe-4e33-a0a3-09ae126c072f
md"""
## Functions to convolve and to build images from matrices
"""

# ╔═╡ 67379d2a-f7a8-482f-bcc0-bfd1687aba01
begin
	function convolve_rgb(image,kernel)
		# supports 3x3 convolution, convolves each channel directly
		# return: rgb image
		r=0
		g=0
		b=0
		rows = size(image)[1]
		cols = size(image)[2]
		temp = copy(image)
		temp = padarray(temp, Pad(0, 0)) #zeropad to keep size after convolution
		for i=2:rows-2
			for j=2:cols-2			
				for x=0:2
					for y=0:2
						r+= image[i+x,j+y].r * kernel[x-1,y-1]
						g+= image[i+x,j+y].g * kernel[x-1,y-1]
						b+= image[i+x,j+y].b * kernel[x-1,y-1]
					end
				end
				temp[i,j] = RGB(abs(r),abs(g),abs(b))
				r=0
				g=0
				b=0
			end
		end
		return temp
	end
	
	function convolve_gray(image,kernel)
		# supports 3x3 convolution
		# return 2d float64 Matrix
		p=0
		rows = size(image)[1]
		cols = size(image)[2]
		temp = copy(image)
		temp = padarray(temp, Pad(0, 0)) #zeropad to keep size after convolution
		for i=2:rows-2
			for j=2:cols-2			
				for x=0:2
					for y=0:2
						p+= image[i+x,j+y] * kernel[x-1,y-1]
					end
				end
				temp[i,j] = p
				p=0
			end
		end
		return temp
	end
	
	function show_colored_array(array)
		pos_color = RGB(0.36, 0.82, 0.8)
		neg_color = RGB(0.99, 0.18, 0.13)
		to_rgb(x) = max(x, 0) * pos_color + max(-x, 0) * neg_color
		to_rgb.(array) / maximum(abs.(array))
	end
	
	function hbox(x, y, gap=16; sy=size(y), sx=size(x))
		w,h = (max(sx[1], sy[1]),
			   gap + sx[2] + sy[2])

		slate = fill(RGB(1,1,1), w,h)
		slate[1:size(x,1), 1:size(x,2)] .= RGB.(x)
		slate[1:size(y,1), size(x,2) + gap .+ (1:size(y,2))] .= RGB.(y)
		slate
	end
end

# ╔═╡ d9984d08-1604-4ee5-a1c1-0ecf2312e23a
brightness(c::AbstractRGB) = 0.3 * c.r + 0.59 * c.g + 0.11 * c.b

# ╔═╡ c6eba36d-a1a9-4d79-961e-bfd1d7f7e502
@bind n Slider(1:10) # scalar multiplying the sobel kernels

# ╔═╡ 9e8e794f-8b9b-43e5-a810-e448c7e72cad
begin
	Sy, Sx = Kernel.sobel()
	Sy *= n
	Sx *= n
end

# ╔═╡ 6df32996-8d11-48e7-9c20-9eca6f6a4d1c
begin
 	image = brightness.(rem)
 	∇x = convolve_gray(image, Sx)
 	∇y = convolve_gray(image, Sy)
	∇ = sqrt.(∇x.^2 + ∇y.^2)
end

# ╔═╡ eaeb7ccb-155e-43e8-9d89-63f1c045446d
hbox(show_colored_array(∇y),show_colored_array(∇x))

# ╔═╡ 9827a55c-589f-4317-a003-18fc7d59cade
n

# ╔═╡ 1bb1d12c-07f8-465b-af28-7569a540de82
show_colored_array(∇)

# ╔═╡ Cell order:
# ╠═eaf44e44-0f51-11ec-1ad9-954ad43b66c8
# ╟─1575ce99-17fb-4b7b-834f-4bc4eed33053
# ╠═d0d44648-0959-47aa-8553-e2c10e6dc948
# ╠═b4eae467-df6e-4d2a-8c40-2f1ed997fcd9
# ╠═d6529aa6-e680-4695-bcb9-00278b0d5687
# ╠═1e034d75-3252-491d-b9ff-6219f8902179
# ╟─30278719-1c91-48e4-afd1-f227babdcde0
# ╠═8847937f-78a7-4300-b252-5ae302a69d93
# ╠═6c904034-c1ec-4817-b66d-e8d5da1aaeb0
# ╠═a0bd4084-0a4f-4ec4-87d8-090c667fd720
# ╟─1efb1749-7a8c-4762-a130-7faf0ac772a8
# ╠═9e8e794f-8b9b-43e5-a810-e448c7e72cad
# ╟─b89f6aee-94fe-4e33-a0a3-09ae126c072f
# ╠═67379d2a-f7a8-482f-bcc0-bfd1687aba01
# ╠═d9984d08-1604-4ee5-a1c1-0ecf2312e23a
# ╠═6df32996-8d11-48e7-9c20-9eca6f6a4d1c
# ╠═eaeb7ccb-155e-43e8-9d89-63f1c045446d
# ╠═c6eba36d-a1a9-4d79-961e-bfd1d7f7e502
# ╠═9827a55c-589f-4317-a003-18fc7d59cade
# ╠═1bb1d12c-07f8-465b-af28-7569a540de82
