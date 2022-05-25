import React from 'react'
import {
	AttachmentDeleteClass,
	PiSldsAssetsPath,
} from '../constants'

export const AttachmentDeleteButton = ({callback = null}) => {
	return (
		<div className={AttachmentDeleteClass} onClick={callback} style={{
			position: 'absolute',
			bottom: '0.5rem',
			right: '0.25rem',
			cursor: 'pointer',
		}}>
			<div role="group" style={{
				display: 'inline-flex',
			}}>
				<button title="Delete" style={{
					position: 'relative',
					display: 'inline-block',
					padding: 0,
					background: 'transparent',
					backgroundClip: 'border-box',
					border: '1px solid transparent',
					cursor: 'pointer',
					textDecoration: 'none',
					WebkitAppearance: 'none',
					whiteSpace: 'normal',
					userSelect: 'none',
					verticalAlign: 'middle',
					color: '#706e6b',
					width: '1.25rem',
					height: '1.25rem',
					lineHeight: '1',
					borderWidth: '1px',
					borderRadius: '0.25rem',
				}}>
					<img aria-hidden='true' src={`${PiSldsAssetsPath}/icons/utility/close_60.png`} style={{
						lineHeight: 1,
						fill: 'currentColor',
						width: '0.75rem',
						height: '0.75rem',
						pointerEvents: 'none',
					}} />
					<span style={{
						position: 'absolute',
						margin: '-1px',
						border: '0',
						padding: '0',
						width: '1px',
						height: '1px',
						overflow: 'hidden',
						clip: 'rect(0 0 0 0)', textTransform: 'none',
						whiteSpace: 'nowrap',
					}}>"Delete"</span>
				</button>
			</div>
		</div>
	)
}
